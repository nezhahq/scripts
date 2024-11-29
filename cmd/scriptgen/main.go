package main

import (
	"bufio"
	"fmt"
	"os"
	"regexp"
	"strings"

	"github.com/chai2010/gettext-go"
)

const (
	zh_CN = "zh_CN"
	en_US = "en_US"
)

func main() {
	if len(os.Args) != 3 {
		printUsage()
		exitWithError("Error: Need exactly 2 arguments")
	}

	readLocalesFromDir(os.Args[1])

	if err := parseTemplate(os.Args[2]); err != nil {
		exitWithError(fmt.Sprintf("parseTemplate: %v", err))
	}
}

func printUsage() {
	fmt.Printf("usage: %s [localedir] [locale]\n", os.Args[0])
}

func exitWithError(message string) {
	fmt.Fprintln(os.Stderr, message)
	os.Exit(1)
}

func readLocalesFromDir(dir string) {
	gettext.BindLocale(gettext.New("nezha", dir))
}

func parseTemplate(lang string) error {
	gettext.SetLanguage(lang)
	regex := regexp.MustCompile(`_\("([^"]+)"\)`)

	var file *os.File
	var err error
	switch lang {
	case zh_CN:
		file, err = os.Create("install.sh")
		if err != nil {
			return err
		}
		defer file.Close()
	case en_US:
		file, err = os.Create("install_en.sh")
		if err != nil {
			return err
		}
		defer file.Close()
	default:
		return fmt.Errorf("unsupported locale: %s", lang)
	}

	template, err := os.Open("nezha/template.sh")
	if err != nil {
		return err
	}

	var newline string
	scanner := bufio.NewScanner(template)
	buf := make([]byte, 1024*1024)
	scanner.Buffer(buf, len(buf))

	writer := bufio.NewWriter(file)
	defer writer.Flush()

	for scanner.Scan() {
		line := scanner.Text()
		matches := regex.FindAllStringSubmatch(line, -1)

		if len(matches) > 0 {
			orig := matches[0][0]
			translated := fmt.Sprintf("\"%s\"", gettext.PGettext("", matches[0][1]))
			newline = strings.ReplaceAll(line, orig, translated)
		} else {
			newline = line
		}

		_, err := writer.WriteString(fmt.Sprintln(newline))
		if err != nil {
			fmt.Println("Error writing to file:", err)
			return err
		}
	}

	return nil
}

package main

import (
	"fmt"
	"strings"
	"time"

	"github.com/spf13/pflag"
	"github.com/spf13/viper"
)

var (
	inputPaths   []string
	idleWaitTime time.Duration
)

func init() {
	viper := viper.New()
	viper.SetConfigType("toml")
	viper.SetConfigName("config")
	viper.AddConfigPath("/etc/appname/")
	viper.AddConfigPath("$HOME/.appname")
	viper.AddConfigPath(".")
	err := viper.ReadInConfig()
	if err != nil {
		panic(err)
	}

	viper.SetEnvPrefix("KBDBL")
	viper.SetEnvKeyReplacer(strings.NewReplacer("-", "_"))
	viper.AutomaticEnv()

	pflag.DurationP("wait", "w", time.Duration(5), "Turn off the keyboard backlight after {wait} seconds when the selected inputs are idle")
	pflag.StringSliceP("input", "i", []string{"/dev/input/mice"}, "Input files to read from eg. /dev/input/mice or /dev/input/by-path/platform-i8042-serio-0-event-kbd")

	pflag.Parse()

	viper.BindPFlag("wait-seconds", pflag.Lookup("wait"))
	viper.BindPFlag("inputs", pflag.Lookup("input"))

	idleWaitTime = viper.GetDuration("wait-seconds") // KBDBL_WAIT_SECONDS
	inputPaths = viper.GetStringSlice("inputs")      // KBDBL_INPUTS=comma,separated,values

	fmt.Println("inputs", inputPaths)
	fmt.Println("waitSeconds", idleWaitTime)
}
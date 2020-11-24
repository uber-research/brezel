package main

import (
    "io/ioutil"
    "fmt"
    "os"
)

func check(e error) {
    if e != nil {
        panic(e)
    }
}

func main() {
    // receive config path as first argument
    arg := os.Args[1]

    // display the config content
    dat, err := ioutil.ReadFile(arg)
    check(err)
    fmt.Println("[DEBUG] this is the config I received:")
    fmt.Print(string(dat))

    // our job is done here
    err = os.MkdirAll("/out", 0755)
    f, err := os.Create("/out/DONE")
    check(err)
    defer f.Close()
    fmt.Println("[DEBUG] wrote /out/DONE")
}

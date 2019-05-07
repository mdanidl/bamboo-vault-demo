package main

import (
	"fmt"
	"os"
)

func main() {
	fmt.Println("This is my secret: ", os.Getenv("MY_SECRET_PARAMETER"))
}

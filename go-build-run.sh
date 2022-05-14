#!/bin/bash

go build $(ls *.go)
go run ./$(ls *.go)

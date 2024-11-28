package models

type Response struct {
    Status    string      `json:"status"`
    Message   string      `json:"message"`
    Data interface{} `json:"data"`
}
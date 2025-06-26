package com.offcourse.deleterequest.model.dto;

public enum DeleteRequestStatus {
    REQUEST("0"),
    ACCEPT("1"),
    REJECT("2");

    private final String value;

    DeleteRequestStatus(String value) {
        this.value = value;
    }

    @Override
    public String toString() {
        return this.value;
    }
}

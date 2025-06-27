package com.offcourse.deleterequest.model.dto;

public enum DeleteRequestStatus {
    REQUEST("0"),
    ACCEPT("1"),
    REJECT("2");

    private final String value;

    DeleteRequestStatus(String value) {
        this.value = value;
    }

    public static DeleteRequestStatus toEnum(String status) {
        switch (status) {
            case "0":
                return DeleteRequestStatus.REQUEST;
            case "1":
                return DeleteRequestStatus.ACCEPT;
            default:
                return DeleteRequestStatus.REJECT;
        }
    }

    @Override
    public String toString() {
        return this.value;
    }
}

package com.offcourse.deleterequest.model.dto;

public enum DeleteRequestStatus {
    REQUEST("0"),

    ACCEPT("1"),

    REJECT("2");

    private final String value;

    DeleteRequestStatus(String value) {
        this.value = value;
    }

    public static DeleteRequestStatus statusToEnum(String status) {
        switch (status) {
            case "pending":
                return DeleteRequestStatus.REQUEST;
            case "approved":
                return DeleteRequestStatus.ACCEPT;
            case "rejected":
                return DeleteRequestStatus.REJECT;
            default:
                return null;
        }
    }

    public static DeleteRequestStatus columnToEnum(String value) {
        switch (value) {
            case "0":
                return DeleteRequestStatus.REQUEST;
            case "1":
                return DeleteRequestStatus.ACCEPT;
            case "2":
                return DeleteRequestStatus.REJECT;
            default:
                return null;
        }
    }

    @Override
    public String toString() {
        return this.value;
    }
}

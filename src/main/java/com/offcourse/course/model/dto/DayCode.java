package com.offcourse.course.model.dto;

import java.time.DayOfWeek;

public enum DayCode {
    MONDAY("0", "월"),
    TUESDAY("1", "화"),
    WEDNESDAY("2", "수"),
    THURSDAY("3", "목"),
    FRIDAY("4", "금"),
    SATURDAY("5", "토"),
    SUNDAY("6", "일");

    private final String code;
    private final String name;

    DayCode(String code, String name) {
        this.code = code;
        this.name = name;
    }

    public String getCode() {
        return code;
    }

    public String getName() {
        return name;
    }

    //DayCode로 반환해주는 메소드
    public static DayCode fromCode(String code) {
        for (DayCode d : values()) {
            if (d.code.equals(code)) {
                return d;
            }
        }
        return null;
    }

    //회차 날짜 계산 용
    public DayOfWeek toDayOfWeek() {
        return switch (this) {
            case MONDAY -> DayOfWeek.MONDAY;
            case TUESDAY -> DayOfWeek.TUESDAY;
            case WEDNESDAY -> DayOfWeek.WEDNESDAY;
            case THURSDAY -> DayOfWeek.THURSDAY;
            case FRIDAY -> DayOfWeek.FRIDAY;
            case SATURDAY -> DayOfWeek.SATURDAY;
            case SUNDAY -> DayOfWeek.SUNDAY;
        };
    }

}

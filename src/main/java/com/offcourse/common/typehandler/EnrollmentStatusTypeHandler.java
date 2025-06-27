package com.offcourse.common.typehandler;

import com.offcourse.enrollment.model.dto.EnrollmentStatus;
import org.apache.ibatis.type.BaseTypeHandler;
import org.apache.ibatis.type.JdbcType;

import java.sql.*;

public class EnrollmentStatusTypeHandler extends BaseTypeHandler<EnrollmentStatus> {


//    setNonNullParameter: DB insert/update 시 ENUM → "0" 변환
//    getNullableResult: DB select 시 "0" → ENUM 변환

    @Override
    public void setNonNullParameter(PreparedStatement ps, int i, EnrollmentStatus parameter, JdbcType jdbcType) throws SQLException {
        ps.setString(i, parameter.toString()); // ENUM -> "0", "1", ...
    }

    @Override
    public EnrollmentStatus getNullableResult(ResultSet rs, String columnName) throws SQLException {
        String value = rs.getString(columnName);
        return getEnum(value);
    }

    @Override
    public EnrollmentStatus getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
        String value = rs.getString(columnIndex);
        return getEnum(value);
    }

    @Override
    public EnrollmentStatus getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
        String value = cs.getString(columnIndex);
        return getEnum(value);
    }

    private EnrollmentStatus getEnum(String value) {
        for (EnrollmentStatus status : EnrollmentStatus.values()) {
            if (status.toString().equals(value)) {
                return status;
            }
        }
        return null;
    }
}

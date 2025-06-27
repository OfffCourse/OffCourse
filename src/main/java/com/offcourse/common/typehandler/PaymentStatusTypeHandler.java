package com.offcourse.common.typehandler;

import com.offcourse.payment.model.dto.PaymentStatus;
import org.apache.ibatis.type.BaseTypeHandler;
import org.apache.ibatis.type.JdbcType;

import java.sql.*;

public class PaymentStatusTypeHandler extends BaseTypeHandler<PaymentStatus> {

    @Override
    public void setNonNullParameter(PreparedStatement ps, int i, PaymentStatus parameter, JdbcType jdbcType) throws SQLException {
        ps.setString(i, parameter.toString()); // value ("0", "1", "2") 저장
    }

    @Override
    public PaymentStatus getNullableResult(ResultSet rs, String columnName) throws SQLException {
        String value = rs.getString(columnName);
        return getPaymentStatus(value);
    }

    @Override
    public PaymentStatus getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
        String value = rs.getString(columnIndex);
        return getPaymentStatus(value);
    }

    @Override
    public PaymentStatus getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
        String value = cs.getString(columnIndex);
        return getPaymentStatus(value);
    }

    private PaymentStatus getPaymentStatus(String value) {
        for (PaymentStatus ps : PaymentStatus.values()) {
            if (ps.toString().equals(value)) {
                return ps;
            }
        }
        return null;
    }
}

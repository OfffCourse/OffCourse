package com.offcourse.common.typehandler;

import com.offcourse.deleterequest.model.dto.DeleteRequestStatus;
import org.apache.ibatis.type.BaseTypeHandler;
import org.apache.ibatis.type.JdbcType;

import java.sql.CallableStatement;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class DeleteRequestTypeHandler extends BaseTypeHandler<DeleteRequestStatus> {
    @Override
    public void setNonNullParameter(PreparedStatement ps, int i, DeleteRequestStatus parameter, JdbcType jdbcType) throws SQLException {
        ps.setString(i, parameter.toString());
    }

    @Override
    public DeleteRequestStatus getNullableResult(ResultSet rs, String columnName) throws SQLException {
        String value = rs.getString(columnName);
        return value != null ? DeleteRequestStatus.toEnum(value) : null;
    }

    @Override
    public DeleteRequestStatus getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
        String value = rs.getString(columnIndex);
        return value != null ? DeleteRequestStatus.toEnum(value) : null;
    }

    @Override
    public DeleteRequestStatus getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
        String value = cs.getString(columnIndex);
        return value != null ? DeleteRequestStatus.toEnum(value) : null;
    }
}

package com.offcourse.payment.model.dao;

import com.offcourse.payment.model.dto.PaymentHistory;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import java.util.HashMap;
import java.util.Map;

@Repository
public class PaymentHistoryDaoImpl implements PaymentHistoryDao {

    private final SqlSessionTemplate sqlSession;
    private static final String NAMESPACE = "paymentHistory.";

    public PaymentHistoryDaoImpl(SqlSessionTemplate sqlSession) {
        this.sqlSession = sqlSession;
    }

    @Override
    public int insertPaymentHistory(PaymentHistory ph) {
        return sqlSession.insert(NAMESPACE + "insertPaymentHistory", ph);
    }

    @Override
    public int updatePaymentStatus(Long paymentSeq, String status) {
        Map<String,Object> params = new HashMap<>();
        params.put("paymentSeq", paymentSeq);
        params.put("status", status);
        return sqlSession.update(NAMESPACE + "updatePaymentStatus", params);
    }

    @Override
    public PaymentHistory selectByOrderId(String orderId) {
        return sqlSession.selectOne(NAMESPACE + "selectByOrderId", orderId);
    }
}

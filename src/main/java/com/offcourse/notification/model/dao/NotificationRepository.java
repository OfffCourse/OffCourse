package com.offcourse.notification.model.dao;

import com.offcourse.notification.exception.NotificationBatchUpdateException;
import com.offcourse.notification.model.dto.NotificationEvent;
import lombok.RequiredArgsConstructor;
import org.apache.ibatis.executor.BatchResult;
import org.apache.ibatis.session.ExecutorType;
import org.apache.ibatis.session.SqlSession;
import org.apache.ibatis.session.SqlSessionFactory;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import java.util.Arrays;
import java.util.List;
import java.util.Map;

@Repository
@RequiredArgsConstructor
public class NotificationRepository {
    private final SqlSessionTemplate session;
    private final SqlSessionFactory sqlSessionFactory;
    private static final int CHUNK_SIZE = 1000;


    public int insertNotification(NotificationEvent event) {
        return session.insert("notification.insertNotification", event);
    }

    public List<NotificationEvent> findReadNotificationNoOffset(Long memberSeq, Long lastMsgSeq, int size) {
        return session.selectList("notification.findReadNotificationNoOffset", Map.of("memberSeq", memberSeq, "lastMsgSeq", lastMsgSeq, "size", size));
    }

    public List<NotificationEvent> findUnreadNotificationNoOffset(Long memberSeq, Long lastMsgSeq, int size) {
        return session.selectList("notification.findUnreadNotificationNoOffset", Map.of("memberSeq", memberSeq, "lastMsgSeq", lastMsgSeq, "size", size));
    }

    public List<NotificationEvent> findAllNotificationNoOffset(Long memberSeq, Long lastMsgSeq, int size) {
        return session.selectList("notification.findAllNotificationNoOffset", Map.of("memberSeq", memberSeq, "lastMsgSeq", lastMsgSeq, "size", size));
    }

    public int countUnreadNotificationAllByMemberSeq(Long memberSeq) {
        return session.selectOne("notification.countUnreadNotificationAllByMemberSeq", memberSeq);
    }

    public int countNotificationAllByMemberSeq(Long memberSeq) {
        return session.selectOne("notification.countNotificationAllByMemberSeq", memberSeq);
    }

    public int countReadNotificationAllByMemberSeq(Long memberSeq) {
        return session.selectOne("notification.countReadNotificationAllByMemberSeq", memberSeq);
    }

    public int markAllAsRead(Long memberSeq) {
        return session.update("notification.markAllAsRead", memberSeq);
    }

    public void markSelectedAsRead(List<Long> msgSeqList, int count) {
        SqlSession batchSession = sqlSessionFactory.openSession(ExecutorType.BATCH, false);
        int totalUpdated = 0;

        try {
            for (int i = 0; i < msgSeqList.size(); i++) {
                Long msgSeq = msgSeqList.get(i);
                batchSession.update("notification.markAsRead", msgSeq);

                // CHUNK_SIZE마다 flushStatements 실행해서 메모리 부담을 줄임
                if ((i + 1) % CHUNK_SIZE == 0) {
                    totalUpdated += flushAndCount(batchSession.flushStatements());
                }
            }

            // 남은 쿼리 flush
            totalUpdated += flushAndCount(batchSession.flushStatements());

            if (totalUpdated != count) {
                batchSession.rollback();
                throw new NotificationBatchUpdateException("업데이트 수 불일치: " + totalUpdated + " vs " + count);
            }

            batchSession.commit();
        } catch (Exception e) {
            batchSession.rollback();
            throw e;
        } finally {
            batchSession.close();
        }
    }

    public void deleteSelectedNotifications(List<Long> msgSeqList) {
        SqlSession batchSession = sqlSessionFactory.openSession(ExecutorType.BATCH, false);
        int totalUpdated = 0;

        try {
            for (int i = 0; i < msgSeqList.size(); i++) {
                Long msgSeq = msgSeqList.get(i);
                batchSession.update("notification.deleteSelectedNotifications", msgSeq);

                // CHUNK_SIZE마다 flushStatements 실행해서 메모리 부담을 줄임
                if ((i + 1) % CHUNK_SIZE == 0) {
                    totalUpdated += flushAndCount(batchSession.flushStatements());
                }
            }

            // 남은 쿼리 flush
            totalUpdated += flushAndCount(batchSession.flushStatements());

            if (totalUpdated != msgSeqList.size()) {
                batchSession.rollback();
                throw new NotificationBatchUpdateException("업데이트 수 불일치: " + totalUpdated + " vs " + msgSeqList.size());
            }

            batchSession.commit();
        } catch (Exception e) {
            batchSession.rollback();
            throw e;
        } finally {
            batchSession.close();
        }
    }

    private int flushAndCount(List<BatchResult> results) {
        return results.stream()
                .mapToInt(r -> Arrays.stream(r.getUpdateCounts()).sum())
                .sum();
    }
}

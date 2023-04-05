package com.deshop.credit.service.impl;

import com.deshop.credit.modle.GradeComposition;
import com.deshop.credit.modle.SyncState;
import com.deshop.credit.service.GradeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

@Service
public class GreadeServiceImpl implements GradeService {

    @Autowired
    RedisTemplate redisTemplate;

    @Override
    public Long getChainLinkGrade(String address) {
        // TODO 从redis 获取数据
        return null;
    }

    @Override
    public GradeComposition getGrade(String address) {
        return null;
    }

    @Override
    public SyncState getSyncState(String address) {
        return null;
    }
}

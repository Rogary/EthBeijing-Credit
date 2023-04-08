package com.deshop.credit.service.impl;

import com.deshop.credit.modle.Composition;
import com.deshop.credit.modle.SyncState;
import com.deshop.credit.service.GradeService;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

@Service
public class GreadeServiceImpl implements GradeService {

    @Override
    public Long getChainLinkGrade(String address) {
        // TODO 从redis 获取数据
        return null;
    }

    @Override
    public List<Composition> getGrade(String address) {
        Random random = new Random();
        List<Composition> compositions = new ArrayList<>();
        compositions.add(new Composition("a",100, random.nextInt(100)));
        compositions.add(new Composition("b",100, random.nextInt(100)));
        compositions.add(new Composition("c",100, random.nextInt(100)));
        compositions.add(new Composition("d",100, random.nextInt(100)));
        compositions.add(new Composition("e",100, random.nextInt(100)));
        compositions.add(new Composition("f",100, random.nextInt(100)));
        compositions.add(new Composition("g",100, random.nextInt(100)));
        return compositions;
    }

    @Override
    public SyncState getSyncState(String address) {
        return SyncState.READY;
    }
}

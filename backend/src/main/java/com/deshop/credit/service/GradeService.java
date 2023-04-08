package com.deshop.credit.service;

import com.deshop.credit.modle.Composition;
import com.deshop.credit.modle.SyncState;

import java.util.List;

public interface GradeService {
    Long getChainLinkGrade(String address);

    List<Composition> getGrade(String address);

    SyncState getSyncState(String address);
}

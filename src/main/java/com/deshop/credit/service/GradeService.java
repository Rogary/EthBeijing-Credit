package com.deshop.credit.service;

import com.deshop.credit.modle.GradeComposition;
import com.deshop.credit.modle.SyncState;

public interface GradeService {
    Long getChainLinkGrade(String address);

    GradeComposition getGrade(String address);

    SyncState getSyncState(String address);
}

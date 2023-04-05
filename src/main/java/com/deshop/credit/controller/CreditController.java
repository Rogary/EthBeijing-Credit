package com.deshop.credit.controller;

import com.deshop.credit.modle.GradeComposition;
import com.deshop.credit.service.GradeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/credit")
public class CreditController {

    @Autowired
    GradeService gradeService;

    /**
     * 同步计算数据
     * @param address 用户钱包地址
     * @return
     */
    @GetMapping("/sync")
    public ResponseEntity syncGrade(String address){
        //TODO 扫链 生成数据 存入redis
        return ResponseEntity.ok().build();
    }

    /***
     * 查询同步状态
     * @param address 用户钱包地址
     * @return
     */
    @GetMapping("/sync/state")
    public ResponseEntity syncState(String address){
        return ResponseEntity.ok(gradeService.getSyncState(address));
    }

    @GetMapping("/grade")
    public ResponseEntity<GradeComposition> getGrade(String address){
        return ResponseEntity.ok(gradeService.getGrade(address));
    }

    @GetMapping("/chainlink/grade")
    public ResponseEntity getChainLinkGrade(String address){
        return ResponseEntity.ok(gradeService.getChainLinkGrade(address));
    }
}

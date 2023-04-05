package com.deshop.credit.modle;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class Composition {
    private String name;
    private Long max;
    private Long grade;
}

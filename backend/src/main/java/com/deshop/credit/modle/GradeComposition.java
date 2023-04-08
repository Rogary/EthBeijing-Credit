package com.deshop.credit.modle;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class GradeComposition {
    public Integer grade;
    public List<Composition> compositions;
}

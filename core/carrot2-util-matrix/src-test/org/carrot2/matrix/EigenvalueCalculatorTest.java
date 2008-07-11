package org.carrot2.matrix;

import static org.carrot2.util.test.Assertions.assertThat;

import java.util.Arrays;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.junitext.Prerequisite;
import org.junitext.runners.AnnotationRunner;

import cern.colt.matrix.DoubleMatrix2D;
import cern.colt.matrix.NNIDoubleFactory2D;
import cern.colt.matrix.impl.DenseDoubleMatrix2D;
import cern.colt.matrix.linalg.EigenvalueDecomposition;

/**
 * Test cases for {@link EigenvalueCalculator}.
 */
@RunWith(AnnotationRunner.class)
public class EigenvalueCalculatorTest extends NNITestBase
{
    /** Default delta for comparisons */
    private static final double DELTA = 1e-6;

    /** The test input matrix */
    private DoubleMatrix2D A = NNIDoubleFactory2D.nni.make(new double [] []
    {
        {
            1.00, 7.00, 0.00, 1.00, 0.00
        },
        {
            4.00, 2.00, 0.00, 0.00, 0.00
        },
        {
            0.00, 2.00, 3.00, 7.00, 9.00
        },
        {
            1.00, 5.00, 4.00, 4.00, 3.00
        },
        {
            0.00, 0.00, 6.00, 3.00, 5.00
        }
    });

    @Test
    public void testSymmetrical()
    {
        DoubleMatrix2D Asym = A.zMult(A, null, 1, 0, true, false);
        double [] expectedEigenvalues = new EigenvalueDecomposition(Asym)
            .getRealEigenvalues().toArray();
        Arrays.sort(expectedEigenvalues);

        double [] eigenvalues = EigenvalueCalculator.computeEigenvaluesSymmetrical(Asym);
        Arrays.sort(eigenvalues);

        assertThat(expectedEigenvalues).isEqualTo(expectedEigenvalues, DELTA);
    }

    @Test
    @Prerequisite(requires = "nativeLapackAvailable")
    public void testAsymmetrical()
    {
        double [] eigenvalues = EigenvalueCalculator
            .computeEigenvaluesNNI((DenseDoubleMatrix2D) A);
        Arrays.sort(eigenvalues);

        double [] expectedEigenvalues = new EigenvalueDecomposition(A)
            .getRealEigenvalues().toArray();
        Arrays.sort(expectedEigenvalues);

        assertThat(expectedEigenvalues).isEqualTo(expectedEigenvalues, DELTA);
    }
}
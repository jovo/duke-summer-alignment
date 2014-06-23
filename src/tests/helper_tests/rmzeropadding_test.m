classdef rmzeropadding_test < matlab.unittest.TestCase
    %RMZEROPADDING_TEST 
    %   rmzeropadding_test 
    
    methods (Test)
        function testFlatImage(testCase) % test image all zeros, force = 0
            M = zeros();
            [M_new,yshiftmin,xshiftmin,yshiftmax,xshiftmax] = rmzeropadding(M,force);
         
            testCase.verifyEqual(size(M),size(M_new));
            testCase.verifyEqual(yshiftmin,0);
            testCase.verifyEqual(xshiftmin,0);
            testCase.verifyEqual(yshiftmax,0);
            testCase.verifyEqual(xshiftmax,0);
        end
        function testNonZeroCases(testCase) % test image nonzero, varied force
            M = randi([1,255],2^randi([8,10],1)); 
            [M_new,~,~,~,~] = rmzeropadding(M);
            [M_new1,~,~,~,~] = rmzeropadding(M,1);
            [M_new2,~,~,~,~] = rmzeropadding(M,2);
            
            testCase.verifyEqual(M-M_new,zeros(size(M)));
            testCase.verifyEqual(M-M_new1,zeros(size(M)));
            testCase.verifyEqual(M-M_new2,zeros(size(M)));
        end
        function testZeroCases1(testCase)
            
        end
    end
end

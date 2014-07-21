classdef rmzeropadding_test < matlab.unittest.TestCase
    %RMZEROPADDING_TEST compares padding removal in various cases
    %   rmzeropadding_test verifies that padding removed is correct based 
    %   on force
    
    methods (Test)
        function testFlatImage(testCase) 
            % test image all zeros, force = 0
            M = zeros(5);
            [M_new,yshiftmin,xshiftmin,yshiftmax,xshiftmax] = rmzeropadding(M);
            % checks matrix sizes and x,y shifts
            testCase.verifyEqual(size(M),size(M_new));
            testCase.verifyEqual(yshiftmin,0);
            testCase.verifyEqual(xshiftmin,0);
            testCase.verifyEqual(yshiftmax,0);
            testCase.verifyEqual(xshiftmax,0);
        end
        function testNonZeroCases(testCase) 
            % test image all nonzero, varied force
            M = randi([1,10],[5,5]); 
            [M_new,~,~,~,~] = rmzeropadding(M);
            [M_new1,~,~,~,~] = rmzeropadding(M,1);
            [M_new2,~,~,~,~] = rmzeropadding(M,2);
            % checks for no changes via pixel dif
            testCase.verifyEqual(M-M_new,zeros(size(M)));
            testCase.verifyEqual(M-M_new1,zeros(size(M)));
            testCase.verifyEqual(M-M_new2,zeros(size(M)));
        end
        function testCornerCases1_1(testCase)
            % test image has 0 in UL corner, varied force
            M = [ ... 
                 0, randi([1,10],[1,4]); ...
                 randi([1,10],[4,5]); ...
                ];
            [M_new,~,~,~,~] = rmzeropadding(M);
            [M_new1,~,~,~,~] = rmzeropadding(M,1);
            [~,yshiftmin,xshiftmin,~,~] = rmzeropadding(M,2);
            % checks for no changes via pixel dif
            testCase.verifyEqual(M-M_new,zeros(size(M)));
            testCase.verifyEqual(M-M_new1,zeros(size(M)));
            testCase.verifyEqual(yshiftmin,1);
            testCase.verifyEqual(xshiftmin,1);
        end
        function testCornerCases1_2(testCase)
            % test image has 0s in UL corner, varied force
            M = [ ... 
                 0,0,randi([1,10],[1,3]); ...
                 randi([1,10],[4,5]); ...
                ];
            [M_new,~,~,~,~] = rmzeropadding(M);
            [M_new1,~,~,~,~] = rmzeropadding(M,1);
            [~,yshiftmin,xshiftmin,~,~] = rmzeropadding(M,2);
            % checks for no changes via pixel dif
            testCase.verifyEqual(M-M_new,zeros(size(M)));
            testCase.verifyEqual(M-M_new1,zeros(size(M)));
            testCase.verifyEqual(yshiftmin,1);
            testCase.verifyEqual(xshiftmin,1);
        end
         function testCornerCases1_3(testCase)
            % test image has 0s in LR corner, varied force
            M = [ ... 
                 0,0,randi([1,10],[1,3]); ...
                 randi([1,10],[1,1]),0,randi([1,10],[1,3]); ...
                 randi([1,10],[3,5]); ...
                ];
            [M_new,~,~,~,~] = rmzeropadding(M);
            [M_new1,~,~,~,~] = rmzeropadding(M,1);
            [~,yshiftmin,xshiftmin,~,~] = rmzeropadding(M,2);
            % checks for no changes via pixel dif
            testCase.verifyEqual(M-M_new,zeros(size(M)));
            testCase.verifyEqual(M-M_new1,zeros(size(M)));
            testCase.verifyEqual(yshiftmin,2);
            testCase.verifyEqual(xshiftmin,2);
        end
        function testCornerCases2_1(testCase)
            % test image has 0 in LR corner, varied force
            M = [ ... 
                 randi([1,10],[4,5]); ...
                 randi([1,10],[1,4]),0; ...
                ];
            [M_new,~,~,~,~] = rmzeropadding(M);
            [M_new1,~,~,~,~] = rmzeropadding(M,1);
            [~,~,~,yshiftmax,xshiftmax] = rmzeropadding(M,2);
            % checks for no changes via pixel dif
            testCase.verifyEqual(M-M_new,zeros(size(M)));
            testCase.verifyEqual(M-M_new1,zeros(size(M)));
            testCase.verifyEqual(yshiftmax,1);
            testCase.verifyEqual(xshiftmax,1);
        end
        function testCornerCases2_2(testCase)
            % test image has 0s in LR corner, varied force
            M = [ ... 
                 randi([1,10],[4,5]); ...
                 randi([1,10],[1,3]),0,0; ...
                ];
            [M_new,~,~,~,~] = rmzeropadding(M);
            [M_new1,~,~,~,~] = rmzeropadding(M,1);
            [~,~,~,yshiftmax,xshiftmax] = rmzeropadding(M,2);
            % checks for no changes via pixel dif
            testCase.verifyEqual(M-M_new,zeros(size(M)));
            testCase.verifyEqual(M-M_new1,zeros(size(M)));
            testCase.verifyEqual(yshiftmax,1);
            testCase.verifyEqual(xshiftmax,1);
        end
        function testCornerCases2_3(testCase)
            % test image has 0s in LR corner, varied force
            M = [ ... 
                 randi([1,10],[3,5]); ...
                 randi([1,10],[1,3]),0,randi([1,10],[1,1]); ...
                 randi([1,10],[1,3]),0,0; ...
                ];
            [M_new,~,~,~,~] = rmzeropadding(M);
            [M_new1,~,~,~,~] = rmzeropadding(M,1);
            [~,~,~,yshiftmax,xshiftmax] = rmzeropadding(M,2);
            % checks for no changes via pixel dif
            testCase.verifyEqual(M-M_new,zeros(size(M)));
            testCase.verifyEqual(M-M_new1,zeros(size(M)));
            testCase.verifyEqual(yshiftmax,2);
            testCase.verifyEqual(xshiftmax,2);
        end  
    end
end

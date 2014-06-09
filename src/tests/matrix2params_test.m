classdef matrix2params_test < matlab.unittest.TestCase
    %MATRIX2PARAMS_TEST compares transformations in matrix and vector forms
    %   matrix2params_test checks to see if parameters vector contains same
    %   inputs as matrix of transformations 
    
    properties
        OriginalPath 
    end
    
    methods (Test) 
        function testRealSolution(testCase)
            actSoln = ;
            expSoln = ;
            testCase.verifyEqual(actSoln,expSoln,
        end
    end
    
end

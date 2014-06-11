classdef matrix2params_test < matlab.unittest.TestCase
    %MATRIX2PARAMS_TEST compares transformations 
    %   matrix2params_test checks to see if parameters vector contains same
    %   inputs as matrix of transformations 
    
    properties
        OriginalPath 
    end
    
    methods (TestMethodSetup)
        function addSolverToPath(testCase)
        testCase.OriginalPath = path;
        addpath(fullfile(pwd,' '));
        end
    end
    
    methods (Test) 
        function testTransformations(testCase)
            actTx = params(2);
            expTx = matrix(3,1);
            actTy = params(1);
            expTy = matrix(3,2);
            actTHETA = params(3);
            expTHETA = acos(matrix(1,1)) * 180/pi;
            actSCALE = params(4);
            expSCALE = sqrt(matrix(1,1)^2 + matrix(2,1)^2);
            testCase.verifyEqual(actTx, expTx);
            testCase.verifyEqual(actTy, expTy);
            testCase.verifyEqual(actTHETA, expTHETA);
            testCase.verifyEqual(actSCALE, expSCALE);
        end
    end
end

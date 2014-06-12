classdef matrix2params_test < matlab.unittest.TestCase
    %MATRIX2PARAMS_TEST compares transformations in matrix and vector forms
    %   matrix2params_test checks to see if parameters vector contains same
    %   inputs as matrix of transformations 
   
    methods (Test) 
        function testTransformations(testCase)
            theta = rand(1)*360;
            c1 = [cosd(theta) -sind(theta) 0];
            c2 = [sind(theta) cosd(theta) 0];
            matrix = [c1;c2;[randn(1,2),1]];
            params = matrix2params(matrix);
            
            %transformations 
            actTx = params(2);
            expTx = matrix(3,1);
            actTy = params(1);
            expTy = matrix(3,2);
            
            if params(3) < 0;
                actTHETA = round((params(3)+360)*1e10)*(1e-10);
                expTHETA = round((360-acosd(matrix(1,1)))*1e10)*(1e-10);
            else
                actTHETA = round((params(3))*1e10)*(1e-10);
                expTHETA = round((acosd(matrix(1,1)))*(1e10))*(1e-10);
            end
            
            actSCALE = params(4);
            expSCALE = sqrt(matrix(1,1)^2 + matrix(2,1)^2);
            
            % tests for equality 
            testCase.verifyEqual(actTx, expTx);
            testCase.verifyEqual(actTy, expTy);
            testCase.verifyEqual(actTHETA, expTHETA);
            testCase.verifyEqual(actSCALE, expSCALE);
        end
    end
    
end

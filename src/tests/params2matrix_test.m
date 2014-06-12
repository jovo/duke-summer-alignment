classdef params2matrix_test < matlab.unittest.TestCase
    %PARAMS2MATRIX_TEST compares transformations in vector and matrix form
    %   params2matrix_test checks to see if matrix of transformations contains same
    %   inputs as parameters vector
    
    methods (Test)
        function testTransformations(testCase)
            theta = rand(1)*360;
            params = [randn(1,2) theta 1 0];
            matrix = params2matrix(params);
            
            % transformations 
            actTx = matrix(3,1);
            expTx = params(2);
            actTy = matrix(3,2);
            expTy = params(1);
            
            if params(3) < 0; 
                actTHETA = round((360-acosd(matrix(1,1)))*1e10)*(1e-10);
                expTHETA = round((params(3)+360)*1e10)*(1e-10);
            elseif params(3) > 180;
                actTHETA = round((360-acosd(matrix(1,1)))*1e10)*(1e-10);
                expTHETA = round((params(3))*1e10)*(1e-10);
                else
                actTHETA = round((acosd(matrix(1,1)))*1e10)*(1e-10);
                expTHETA = round((params(3))*1e10)*(1e-10);
            end
                                                     
            actSCALE = round((sqrt(matrix(1,1)^2 + matrix(2,1)^2))*1e10)*(1e-10);
            expSCALE = params(4); 
            
            % tests for equality 
            testCase.verifyEqual(actTx, expTx);
            testCase.verifyEqual(actTy, expTy);
            testCase.verifyEqual(actTHETA, expTHETA);
            testCase.verifyEqual(actSCALE, expSCALE);
        end
    end
end

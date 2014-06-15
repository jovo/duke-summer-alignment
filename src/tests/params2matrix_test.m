classdef params2matrix_test < matlab.unittest.TestCase
    %PARAMS2MATRIX_TEST compares transformations in vector and matrix form
    %   params2matrix_test checks to see if matrix of transformations contains same
    %   inputs as parameters vector
    
    methods (Test)
        function testTransformations(testCase)
            % specify range [a,b] of randomly generated translations
            a = -10;
            b = 10;
            
            theta = (2*rand(1,1)-1)*360;
            params = [(b-a).*rand(1,2)+a, theta];
            matrix = params2matrix(params);
            
            % transformations 
            actTx = matrix(3,1);
            expTx = params(2);
            actTy = matrix(3,2);
            expTy = params(1);
            
            if params(3) < 0; 
                if params(3) < -180;
                    actTHETA = round((-360+acosd(matrix(1,1)))*1e10)*(1e-10);
                else
                actTHETA = round(-acosd(matrix(1,1))*1e10)*(1e-10);
                end
            elseif params(3) > 180;
                actTHETA = round((360-acosd(matrix(1,1)))*1e10)*(1e-10);
                else
                actTHETA = round((acosd(matrix(1,1)))*1e10)*(1e-10); 
            end
            expTHETA = round((params(3))*1e10)*(1e-10);
            
            % tests for equality 
            testCase.verifyEqual(actTx, expTx);
            testCase.verifyEqual(actTy, expTy);
            testCase.verifyEqual(actTHETA, expTHETA);
        end
    end
end 

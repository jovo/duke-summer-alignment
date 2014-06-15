classdef matrix2params_test < matlab.unittest.TestCase
    %MATRIX2PARAMS_TEST compares transformations in matrix and vector forms
    %   matrix2params_test checks to see if parameters vector contains same
    %   inputs as matrix of transformations 
   
    methods (Test) 
        function testTransformations(testCase)
            % specify range [a,b] of randomly generated translations
            a = -10;
            b = 10;
            
            theta = rand(1)*360;
            c1 = [cosd(theta) -sind(theta) 0];
            c2 = [sind(theta) cosd(theta) 0];
            c3 = [(b-a).*rand(1,2)+a,1];
            matrix = [c1;c2;c3]; 
            params = matrix2params(matrix);
            
            % transformations 
            actTx = params(2);
            expTx = matrix(3,1);
            actTy = params(1);
            expTy = matrix(3,2);
            
            actTHETA = round(mod(params(3),360)*1e10)*(1e-10);
            if params(3) < 0;
                expTHETA = round((360-acosd(matrix(1,1)))*1e10)*(1e-10);
            else
                expTHETA = round((acosd(matrix(1,1)))*(1e10))*(1e-10);
            end
            
            % tests for equality 
            testCase.verifyEqual(actTx, expTx);
            testCase.verifyEqual(actTy, expTy);
            testCase.verifyEqual(actTHETA, expTHETA);
        end
    end
    
end

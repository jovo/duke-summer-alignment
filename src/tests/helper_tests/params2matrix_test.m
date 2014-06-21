classdef params2matrix_test < matlab.unittest.TestCase
    %PARAMS2MATRIX_TEST compares transformations in vector and matrix form
    %   params2matrix_test checks to see if matrix of transformations contains same
    %   inputs as parameters vector
    
    methods (Test)
        function testTransformations(testCase)
            theta = (2*rand(1,1)-1)*360;
            params = [randi([-10,10],[1,2]), theta]; % assumes range of translations = [-10,10]
            matrix = params2matrix(params);
            rot = [cosd(theta),-sind(theta);sind(theta),cosd(theta)];
            
            % translations
            X = linsolve(rot,[matrix(3,1);matrix(3,2)]);
            actTx = X(1); 
            expTx = params(2);
            actTy = X(2); 
            expTy = params(1);
            
            % rotation 
            if params(3) < 0; 
                if params(3) < -180;
                    actTHETA = -360+acosd(matrix(1,1));
                else
                actTHETA = -acosd(matrix(1,1));
                end
            elseif params(3) > 180;
                actTHETA = 360-acosd(matrix(1,1));
                else
                actTHETA = acosd(matrix(1,1)); 
            end
            expTHETA = params(3);
            
            % tests for equality within perscribed tolerance 
            testCase.verifyEqual(actTx,expTx,'AbsTol',1e-10);
            testCase.verifyEqual(actTy,expTy,'AbsTol',1e-10);
            testCase.verifyEqual(actTHETA,expTHETA,'AbsTol',1e-10);
        end
    end
end 

classdef matrix2params_test < matlab.unittest.TestCase
    %MATRIX2PARAMS_TEST compares transformations in matrix and vector forms
    %   matrix2params_test checks to see if parameters vector contains same
    %   inputs as matrix of transformations 
   
    methods (Test) 
        function testTransformations(testCase)
            theta = (2*rand(1,1)-1)*360;
            trans = [...
                       1,  0,  0; ...
                       0,  1,  0; ...
                       randi([-10,10],[1,2]) , 1 ...
                    ]; % assumes range of translations = [-10,10]
            rot = [...
                     cosd(theta),  sind(theta), 0; ...
                     -sind(theta), cosd(theta), 0; ...
                     0,            0,           1  ...
                  ];
            matrix = trans*rot;  
            params = matrix2params(matrix);
            
            % translation
            actTx = params(2);
            expTx = trans(3,1);
            actTy = params(1);
            expTy = trans(3,2);
            
            % rotation
            actTHETA = mod(params(3),360);
            if params(3) < 0;
                if params(3) < -180;
                    expTHETA = acosd(rot(1,1));
                else    
                expTHETA = 360-acosd(rot(1,1));
                end
            elseif params(3) > 180;
                expTHETA = 360-acosd(rot(1,1));
                else
                expTHETA = acosd(rot(1,1));
            end
            
            % tests for equality within perscribed tolerance
            testCase.verifyEqual(actTx,expTx,'AbsTol',1e-10);
            testCase.verifyEqual(actTy,expTy,'AbsTol',1e-10);
            testCase.verifyEqual(actTHETA,expTHETA,'AbsTol',1e-10);
        end
    end
    
end

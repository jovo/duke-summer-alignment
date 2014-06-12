classdef params2matrix_test < matlab.unittest.TestCase
    %PARAMS2MATRIX_TEST compares transformations in vector and matrix form
    %   params2matrix_test checks to see if matrix of transformations contains same
    %   inputs as parameters vector
    
    properties
    end
    
    methods (Test)
        function testTransformations(testCase)
            actTx = matrix(3,1);
            expTx = params(2);
            actTy = matrix(3,2);
            expTy = params(1);
            actTHETA = ;
            expTHETA = params(3);
            actSCALE = ;
            expSCALE = params(4); 
        end
    end

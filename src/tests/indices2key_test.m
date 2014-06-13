classdef indices2key_test < matlab.unittest.TestCase
    %INDICES2KEY_TEST compares input indices and output key
    %   indices2key_test verifies that indices and key are equal 
    
    methods (Test)
        function testTransformations(testCase)
            key = indices2key(num1,num2);
            
            % tests for equality 
            testCase.verifyEqual(num1,key(1));
            testCase.verifyEqual(num2, );
        end
    end
end

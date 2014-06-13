classdef indices2key_test < matlab.unittest.TestCase
    %INDICES2KEY_TEST compares input indices and output key
    %   indices2key_test verifies that indices and key are equal 
    
    methods (Test)
        function testTransformations(testCase)
            num1 = randi([1,1024],1,1); 
            num2 = randi([1,1024],1,1); 
            key = indices2key(num1,num2);
            k = str2num(key); 
            
            % tests for equality 
            testCase.verifyEqual(num1,k(1));
            testCase.verifyEqual(num2,k(2));
        end
    end
end

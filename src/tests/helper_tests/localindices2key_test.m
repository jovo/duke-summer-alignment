classdef localindices2key_test < matlab.unittest.TestCase
    %LOCALINDICES2KEY_TEST compares input indices and output key
    %   localindices2key_test verifies that indices and key are equal 
    
    methods (Test)
        function testKey(testCase)
            num1 = randi(1024,1); 
            num2 = randi(1024,1); 
            key = localindices2key(num1,num2);
            split = strsplit(key,'_');
            k1 = str2double(split(1));
            k2 = str2double(split(2)); 
            % tests for equality 
            testCase.verifyEqual(num1,k1);
            testCase.verifyEqual(num2,k2);
        end
    end
end

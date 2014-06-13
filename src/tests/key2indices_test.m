classdef key2indices_test < matlab.unittest.TestCase
    %KEY2INDICES_TEST compares input key and output indices 
    %   key2indices_test verifies that indices and key are equal 
    
    methods (Test)
        function testTransformations(testCase)
            [num1,num2] = key2indices(key);
            split = strsplit(key);
            
            % tests for equality 
            testCase.verifyEqual(split{1},num1);
            testCase.verifyEqual(split{2},num2);
        end
    end
end

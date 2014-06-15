classdef key2indices_test < matlab.unittest.TestCase
    %KEY2INDICES_TEST compares input key and output indices 
    %   key2indices_test verifies that indices and key are equal 
    
    methods (Test)
        function testIndices(testCase)
            randkey = randi([1,1024],1,2);
            key = num2str(randkey);
            [num1,num2] = key2indices(key);
            
            % tests for equality 
            testCase.verifyEqual(randkey(1),num1);
            testCase.verifyEqual(randkey(2),num2);
        end
    end
end

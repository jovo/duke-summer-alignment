classdef key2indices_test < matlab.unittest.TestCase
    %KEY2INDICES_TEST compares input key and output indices 
    %   key2indices_test verifies that indices and key are equal 
    
    methods (Test)
        function testIndices(testCase)
            rand1 = randi(1024,1);
            rand2 = randi(1024,1);
            randkey = [int2str(rand1),'_',int2str(rand2)];
            key = num2str(randkey);
            [num1,num2] = key2indices(key);
            
            % tests for equality 
            testCase.verifyEqual(rand1,num1);
            testCase.verifyEqual(rand2,num2);
        end
    end
end

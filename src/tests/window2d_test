classdef window2d_test < matlab.unittest.TestCase
    %WINDOW2D_TEST checks to see if window applied correctly 
    
    methods (Test)
        function testHamming(testCase)
            M = randi([0,10],[randi([0,5],[1,2])]);
            y = hamming(size(M,1));
            x = hamming(size(M,2)); 
            M_hamm = M.*(y(:)*x(:)');
            M_new = window2d(M,'hamming');
            testCase.verifyEqual(M_hamm,M_new);
        end
        function testHann(testCase)
            M = randi([0,10],[randi([0,5],[1,2])]);
            y = hann(size(M,1));
            x = hann(size(M,2)); 
            M_hann = M.*(y(:)*x(:)');
            M_new = window2d(M,'hann');
            testCase.verifyEqual(M_hann,M_new);
        end
    end
    
end

classdef Stack < handle
%STACK simple stack data structure.
    properties (SetAccess = private, GetAccess = private)
        container;
        top;
        
    end
    
    methods
        function stack = Stack(varargin)    % constructor
            narginchk(0,1);
            switch nargin
                case 0
                    stack.container = cell(10, 1);

                case 1
                    stack.container = cell(varargin{1}, 1);
            end
                stack.top = 0;
        end

        function c = capacity(stack)    % stack capacity
            c = size(stack, 1);
        end
        
        function s = size(stack)        % # elements in stack
            s = stack.top;
        end
        
        function e = isempty(stack)
            e = ~size(stack);
        end
        
        function f = isfull(stack)
            f = size(stack) == capacity(stack);
        end
        
        function push(stack, obj)
            if isfull(stack)
                stack.container = [stack.container; cell(capacity(stack),1)];
            end
            stack.top = stack.top + 1;
            stack.container{stack.top} = obj;
        end
        
        function obj = pop(stack)
            if isempty(stack)
                obj = [];
                warning('EmptyStackException: popping from empty stack');
            else
                obj = stack.container{stack.top};
                stack.container{stack.top} = [];
                stack.top = stack.top - 1;
            end     
        end
    
        function obj = peek(stack)
            if isempty(stack)
                obj = [];
                warning('EmptyStackException: peeking from empty stack');
            else
                obj = stack.container{stack.top};
            end
        end
        
    end 
    
end
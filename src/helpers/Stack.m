classdef Stack < handle
%STACK simple LIFO data structure.
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
            c = size(stack.container, 1);
        end
        
        function s = count(stack)        % # elements in stack
            s = stack.top;
        end
        
        function e = isclear(stack)
            e = ~stack.count();
        end
        
        function f = isfull(stack)
            f = stack.count() == stack.capacity();
        end
        
        function push(stack, obj)
            if stack.isfull()
                stack.container = [stack.container; cell(stack.capacity(),1)];
            end
            stack.top = stack.top + 1;
            stack.container{stack.top} = obj;
        end
        
        function obj = pop(stack)
            if stack.isclear()
                obj = [];
                warning('EmptyStackException: popping from empty stack');
            else
                obj = stack.container{stack.top};
                stack.container{stack.top} = [];
                stack.top = stack.top - 1;
            end     
        end
        
        function obj = peek(stack)
            if stack.isclear()
                obj = [];
                warning('EmptyStackException: peeking from empty stack');
            else
                obj = stack.container{stack.top};
            end
        end
        
    end 
    
end
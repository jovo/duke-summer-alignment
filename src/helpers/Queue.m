classdef Queue < handle
%QUEUE simple FIFO data structure.
    properties (SetAccess = private, GetAccess = private)
        container;
        first;
        last;
        
    end

    methods
        function queue = Queue(varargin)    % constructor
            narginchk(0,1);
            switch nargin
                case 0
                    queue.container = cell(10, 1);

                case 1
                    queue.container = cell(varargin{1}, 1);
            end
                queue.first = 0;
                queue.last = 0;
        end

        function c = capacity(queue)    % stack capacity
            c = size(queue, 1);
        end

        function s = size(queue)        % # elements in stack
            s = queue.last - queue.first;
        end

        function e = isempty(queue)
            e = ~size(queue);
        end

        function f = isfull(queue)
            f = size(queue) == capacity(queue);
        end

        function push(queue, obj)
            if isfull(queue)
                queue.container = [queue.container; cell(capacity(queue),1)];
            end
            queue.last = queue.last + 1;
            queue.container{queue.last} = obj;
        end

        function obj = pop(queue)
            if isempty(queue)
                obj = [];
%                 warning('EmptyStackException: popping from empty queue');
            else
                queue.first = queue.first+1;
                obj = queue.container{queue.first};
                queue.container{queue.first} = [];

            end
            if queue.first > size(queue)/4;    % cut the head of the queue
                queue.container = queue.container(queue.first:capacity(queue));
            end
        end

        function obj = peek(stack)
            if isempty(stack)
                obj = [];
%                 warning('EmptyStackException: peeking from empty queue');
            else
                obj = stack.container{stack.first};
            end
        end
 
    end

end
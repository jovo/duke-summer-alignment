classdef Queue < handle
%QUEUE simple array-based FIFO data structure.
    properties (SetAccess = public, GetAccess = public)
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

        function c = capacity(queue)    % how many elements it can hold
            c = size(queue.container, 1)-queue.first;
        end

        function s = count(queue)        % # elements in queue
            s = queue.last - queue.first;
        end

        function e = isclear(queue)
            e = ~queue.count();
        end

        function f = isfull(queue)
            f = queue.count() == queue.capacity();
        end

        function push(queue, obj)
            if queue.isfull()
                queue.container = [queue.container; cell(queue.capacity(),1)];
            end
            queue.last = queue.last + 1;
            queue.container{queue.last} = obj;
        end

        function obj = pop(queue)
            if queue.isclear()
                obj = [];
%                 warning('EmptyStackException: popping from empty queue');
            else
                queue.first = queue.first+1;
                obj = queue.container{queue.first};
                queue.container{queue.first} = [];
            end
            if queue.first > queue.count()/4;    % cut the head of the queue
                queue.container = queue.container(queue.first + 1: size(queue.container, 1));
                queue.last = queue.last-queue.first;
                queue.first = 0;
            end
        end

        function obj = peek(queue)
            if queue.isclear()
                obj = [];
%                 warning('EmptyStackException: peeking from empty queue');
            else
                obj = queue.container{queue.first+1};
            end
        end
 
    end

end
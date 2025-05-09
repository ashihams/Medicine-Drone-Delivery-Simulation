classdef RotorDirection < int32
    enumeration
        Clockwise (1)
        Anticlockwise (-1)
    end
    methods(Static)
        function map = displayText()
            map = containers.Map;
            map('Clockwise') = 'Clockwise';
            map('Anticlockwise') = 'Anticlockwise';
        end
    end
end
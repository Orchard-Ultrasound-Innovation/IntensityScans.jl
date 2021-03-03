using Dates

function elapsed_time(start_time)
            seconds = floor(time() - start_time)
            return Time(0) + Second(seconds)
end

function elapsed_time(func, start_time)
            seconds = floor(time() - start_time)
            return Time(0) + Second(func(seconds))
end

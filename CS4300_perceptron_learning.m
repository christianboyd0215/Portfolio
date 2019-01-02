function [w,per_cor] = CS4300_perceptron_learning(X,y,alpha,max_iter,rate)
% CS4300_perceptron_learning - find linear separating hyperplane
%  Eqn 18.7, p. 724 Russell and Norvig
% On input:
%     X (nxm array): n independent variable samples each of length m
%     y (nx1 vector): dependent variable samples
%     alpha (float): learning rate
%     max_iter (int): max number of iterations
%     rate (Boolean): if 1 then alpha = 1000/(1000+iter), else constant
% On output:
%     w (m+1x1 vector): weights for linear function
%     per_cor (kx1 array): trace of percentage correct with weight
% Call:
%     [w,pc] = CS4300_perceptron_learning(X,y,0.1,10000,1);
% Author:
%     Christian Boyd
%     Ken Richard
%     UU
%     Fall 2017


    function [weight_out, correct] = perceptronUpdate(weight, percepts, label, alpha)
        %make a prediction
        result = dot(weight, percepts);
        prediction = 0;
        if result >= 0
            prediction = 1;
        end
        sign = label - prediction;
        %update
        for i = 1: length(percepts)
             weight(i) = weight(i)+(alpha*percepts(i)* sign);
        end  
        correct = false;
        if label == prediction
            correct = true;
        end
        weight_out = weight;
    end


[n,m] =  size(X);
notDone = true;
iteration = 0;
weight = [];
X = [ones(n,1), X];
weight = 0.1*(0.5-rand(m+1,1));
output = false;
num_correct = 0;
num_updates = 0;
while(notDone  && iteration <max_iter)
    index = randi(n);
    x = X(index,:);
    hw = x*weight >= 0;
    weight = weight + alpha*(y(index)-hw)*x';
    done = false;
    iteration = iteration + 1;
    per_cor(iteration) = sum((X*weight >= 0)==y)/n;
    if per_cor(end) == 1
        notDone = false;
    end
end
w = weight;

end
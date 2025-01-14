clc;
clear all;

load('HW2_Data.mat')

mu = 0; sigma = 1; size_letters = 784; 
k_count = 10; %class count / output units count

train_images_squared = train_imgs.*train_imgs;
train_bias = ones(60000,1);
train_imgs = [train_imgs train_bias]; 

test_bias = ones(10000,1);
test_imgs = [test_imgs test_bias]; 

train_imgs_T = train_imgs';
test_imgs_T = test_imgs';

nu = 2*10^(-2);

train_labels_one_hot = zeros(10,60000);
for i = 1:60000
    train_labels_one_hot(train_labels(i) + 1,i) = 1;
end

Epochs = 15;
H_Values = [10,20,50];
for H_Layer = H_Values
    % Homogenous coordinates, b should be added
    bias_input = ones(H_Layer, 1);
    hidden_weights = normrnd(mu, sigma, [H_Layer size_letters]);

    W1 = [hidden_weights bias_input]; % Homogenous weights, input bias term added
    output_weights = normrnd(mu, sigma, [k_count H_Layer]);
    W2 = output_weights;

    errors_train = zeros(1,Epochs+1);
    errors_test = zeros(1,Epochs+1);

    err1 = calc_err(W1,W2,train_imgs, train_labels);
    err2 = calc_err(W1,W2,test_imgs, test_labels);
    errors_train(1,1) = err1;
    errors_test(1,1) = err2;

    for Epoch = 1:Epochs
        % Backpropogation loop
        for loop = 1:60000
            x = train_imgs(loop,:);
            % **** FORWARD STEP ****
            g = W1 * x';
            y = (g > 0) .* g;
            u = W2 * y;
            z = exp(u) / sum(exp(u),1); %Softmax

            sens2 = train_labels_one_hot(:,loop) - z; 
            relu_derivative_g = g > 0;
            sens1 = relu_derivative_g .* ((W2')*sens2);

            Grad2 = sens2*y';
            Grad1 = sens1*x;

            W1 = W1 + nu * Grad1;
            W2 = W2 + nu * Grad2;

        end
        err1 = calc_err(W1,W2,train_imgs, train_labels);
        err2 = calc_err(W1,W2,test_imgs, test_labels);
        errors_train(1,Epoch+1) = err1;
        errors_test(1,Epoch+1) = err2;
    end

    figure()
    plot(0:Epochs, errors_train, 'b')
    hold on
    plot(0:Epochs, errors_test, 'r')
    hold off
    xlabel('Epochs');
    xticks(0:Epochs)
    ylabel('Prob of error')
    legend('Train','Test')
    ylim([0 inf])
    title(sprintf('SGD RELU H = %d', H_Layer))
    sprintf('SGD, RELU, H = %d: Train err: %f, Test err: %f', H_Layer, errors_train(1,16),errors_test(1,16))
end
    
function err = calc_err(W1,W2,x, labels)
    g = W1 * x';
    y = (g > 0) .* g;
    u = W2 * y;
    z = exp(u) ./ sum(exp(u),1); %Softmax
    
    [values, indices] = max(z);
    indices = indices - 1;
    err = sum(sum((labels ~= indices'))) / size(x,1);
end
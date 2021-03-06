clear
benchmark = 1; %1 - test data, 2 - coil_100, 3 - film4
% 1 - NHTD(als), 2 - NHTD(hals), 3 - NHTD(xray), 4 - HTD(left_svd_qr)
% 5 - NTD(als), 6 - NTD(hals), 7 - NTD(xray), 8 - HO-SVD
% 9 - FNTD(als), 10 - FNTD(hals), 11 - FNTD(xray), 12 - FTD(svd)
%algs = [1 2 3 4 5 6 7 8 9 10 11];
algs = [1 2 3 4];
SNR = [];
MC = 1;
n_algs = size(algs, 2);

%% setup test params
tol = 1e-5;
maxiters = 100;

%% prepare data
% Xht = generate_ht_tensors(dims, ranks);
% X_ = ht_to_tensor(Xht);
if benchmark == 1
    % dims ranks for this benchmark
    dims = [6 6 6 6 6 6 6 6];
    ranks = {{3,3,3,3,3,3,3,3},{3,3,3,3},{3,3}};
elseif benchmark == 2
    N = size(ranks,2);
    U = [];
    load('data/coil_100.mat')
    X_ = Y;
    ranks = [6 6 3 50 6 6 1];
elseif benchmark == 3
    U = [];
    load('data/film4.mat')
    X_ = X0;
    ranks = [6 8 3 50 6 6 1];
end

N = size(dims, 2);

%% launch tests
results = cell(n_algs,1);
for i=1:n_algs
    results{i} = {};
    results{i}.res = zeros(MC,1);
    results{i}.sir = zeros(MC, N);
    results{i}.msir = zeros(MC,1);
    results{i}.et = zeros(MC,1);
    results{i}.alg = algs(i);
    results{i}.SNR = SNR;
end

for mc=1:MC
    if benchmark == 1
        % Generate core tensors and factor matirces
% 1st approach        
%         Core = max(0,randn(ranks(1:4)));
%         U = cell(1,4);
%         U{1} = max(0,randn(dims(1), ranks(1)));
%         U{2} = max(0,randn(dims(2), ranks(2)));
%         U{3} = max(0,randn(dims(3), ranks(3)));
%         U{4} = max(0,randn(dims(4), ranks(4)));
%         X_ = tensor_contraction(...
%             tensor_contraction(...
%             tensor_contraction(...
%             tensor_contraction(Core, U{1}, 1, 2),...
%             U{2}, 1, 2),...
%             U{3}, 1, 2),...
%             U{4}, 1, 2);
%2nd approach
        Core = sparse_matrix(ranks{1}{1} * ranks{1}{2} * ranks{1}{3} * ranks{1}{4}, ...
            ranks{1}{5} * ranks{1}{6} * ranks{1}{7} * ranks{1}{8}, 0.9);
        Core = reshape(Core, ranks{1}{1:8});
        U = cell(1,8);
        U{1} = sparse_matrix(dims(1), ranks{1}{1}, 0.6);
        U{2} = sparse_matrix(dims(2), ranks{1}{2}, 0.6);
        U{3} = sparse_matrix(dims(3), ranks{1}{3}, 0.6);
        U{4} = sparse_matrix(dims(4), ranks{1}{4}, 0.6);
        U{5} = sparse_matrix(dims(5), ranks{1}{5}, 0.6);
        U{6} = sparse_matrix(dims(6), ranks{1}{6}, 0.6);
        U{7} = sparse_matrix(dims(7), ranks{1}{7}, 0.6);
        U{8} = sparse_matrix(dims(8), ranks{1}{8}, 0.6);
        X_ = tensor_contraction(...
            tensor_contraction(...
            tensor_contraction(...
            tensor_contraction(...
            tensor_contraction(...
            tensor_contraction(...
            tensor_contraction(...
            tensor_contraction(Core, U{1}, 1, 2),...
            U{2}, 1, 2),...
            U{3}, 1, 2),...
            U{4}, 1, 2),...
            U{5}, 1, 2),...
            U{6}, 1, 2),...
            U{7}, 1, 2),...
            U{8}, 1, 2);
%3rd approach
%         Xht = generate_ht_tensors(dims, ranks);
%         U = cell(1,4);
%         U{1} = Xht{1};
%         U{2} = Xht{2};
%         U{3} = Xht{3};
%         U{4} = Xht{4};
%         X_ = ht_to_tensor(Xht);
    end

    if SNR ~= []
        Nt = randn(size(X_)); 
        tau = (norm(X_(:),'fro')/norm(Nt(:), 'fro'))*10^(-SNR/20);
        X = X_ + tau*Nt;
        else
        X = X_;
    end
        
    for i=1:n_algs
        r = launch_alg(X, X_, U, ranks, algs(i),...
            'tol', tol, 'maxiters', maxiters);
        results{i}.res(mc) = r.res;
        results{i}.sir(mc,:) = r.sir;
        results{i}.msir(mc) = r.msir;
        results{i}.et(mc) = r.et;
    end
end

for i=1:n_algs
    results{i}.res_mean = mean(results{i}.res);
    results{i}.msir_mean = mean(results{i}.msir);
    results{i}.et_mean = mean(results{i}.et);
    results{i}.res_std = std(results{i}.res);
    results{i}.msir_std = std(results{i}.msir);
    results{i}.et_std = std(results{i}.et);
end

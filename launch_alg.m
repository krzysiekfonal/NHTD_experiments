function [ results ] = launch_alg( X, X_orig, U, ranks, alg, varargin)

% init results
N = ndims(X);

tic
switch (alg)
    %HT ALGS
    case 1
        Yht = hnt_decomposition(X, ranks, 'als', varargin{1:end});
        if (N == 4)
            Y = ht_to_tensor(Yht);
        else
            Y = ht_to_tensor_8(Yht);
        end
    case 2
        Yht = hnt_decomposition(X, ranks, 'hals', varargin{1:end});
        if (N == 4)
            Y = ht_to_tensor(Yht);
        else
            Y = ht_to_tensor_8(Yht);
        end
    case 3
        Yht = hnt_decomposition(X, ranks, 'xray', varargin{1:end});
        if (N == 4)
            Y = ht_to_tensor(Yht);
        else
            Y = ht_to_tensor_8(Yht);
        end
    case 4
        if (N == 4)
            Yht = ht_decomposition(X, ranks, 'left_svd_qr', varargin{1:end});
            Y = ht_to_tensor(Yht);
        else
            Yht = ht_decomposition_8(X, ranks, 'left_svd_qr', varargin{1:end});
            Y = ht_to_tensor_8(Yht);
        end
        
    % Tucker decompositions    
    case 5
        Yht = ntd_decomposition(X, cell2mat(ranks{1}), 'ntd_als', varargin{1:end});
        Y = tucker_to_tensor(Yht);        
    case 6
        Yht = ntd_decomposition(X, cell2mat(ranks{1}), 'ntd_hals', varargin{1:end});
        Y = tucker_to_tensor(Yht);   

    case 8
        Yht = hosvd_decomposition(X, cell2mat(ranks{1}), 'hosvd', varargin{1:end});
        Y = tucker_to_tensor(Yht);        
    case 9
        Yht = fnt_decomposition(X, cell2mat(ranks{1}), 'als', varargin{1:end});
        Y = tucker_to_tensor(Yht);
    case 10
        Yht = fnt_decomposition(X, cell2mat(ranks{1}), 'hals', varargin{1:end});
        Y = tucker_to_tensor(Yht);
    case 11
        Yht = fnt_decomposition(X, cell2mat(ranks{1}), 'xray', varargin{1:end});
        Y = tucker_to_tensor(Yht);
    case 12
        Yht = fnt_decomposition(X, cell2mat(ranks{1}), 'svd', varargin{1:end});
        Y = tucker_to_tensor(Yht);
        
    % others
    case 13
        T = cell(2,1);
        [T{1}, T{2}] = mlsvd_rsi(X, cell2mat(ranks{1}));
        Yht = cpd_nls(T, cpd_rnd(size(X), ranks{1}{1}));
        Y = ktensor(Yht);
        Y = full(Y);
end
% calculate results
results = {};
results.et = toc;
results.res = calc_res(X_orig, Y);
if ~isempty(U)
    SIR = zeros(1,N);
    for n=1:N
        SIR(n) = mean(CalcSIR(U{n}, Yht{n}));
        results.sir(n) = SIR(n);
    end
    results.msir = mean(SIR(1:4));
end

end


function pars = build_parameters_structure_v4(R, opts, varargin)

%BUILD_PARAMETERS_STRUCTURE Build parameters structure used for function ibTB.

%   Copyright (C) 2009 Cesare Magri
%   Version 4.0.0

% -------
% LICENSE
% -------
% This software is distributed free under the condition that:
%
% 1. it shall not be incorporated in software that is subsequently sold;
%
% 2. the authorship of the software shall be acknowledged and the following
%    article shall be properly cited in any publication that uses results
%    generated by the software:
%
%      Magri C, Whittingstall K, Singh V, Logothetis NK, Panzeri S: A
%      toolbox for the fast information analysis of multiple-site LFP, EEG
%      and spike train recordings. BMC Neuroscience 2009 10(1):81;
%
% 3.  this notice shall remain in place in each source file.

if isempty(varargin)
    msg = 'No output option specified';
    error('buildParsStruct:noOutputOptSpecified', msg);
end

% R -----------------------------------------------------------------------
if ndims(R)==3
    [pars.Nc, size2ofR, pars.Ns] = size(R);
else
    msg = 'Response matrix must be a 3D matrix.';
    error('buildParsStruct:Rnot3D', msg);
end;

% NT ----------------------------------------------------------------------
% If the number of trials per stimulus is constant, NT can be provided 
% as a scalar. In this case, the array version is built internally.
if isscalar(opts.nt)
    pars.Nt = ones(pars.Ns,1) * opts.nt;
    maxNt = pars.Nt;
else
    if length(opts.nt)~=pars.Ns
        msg = 'size(R,3) must match length(opts.nt). Try transposing nt.';
        error('buildParsStruct:lengthNt_vs_size3R', msg);
    end

    % R and NT compatibility:
    pars.Nt = opts.nt(:);
    maxNt = max(pars.Nt);
end

% R and NT compatibility:
if maxNt~=size2ofR
    msg = 'max(nt) must be equal to size(R,2).';
    error('buildParsStruct:maxNt_vs_size2R', msg);
end 

% METHOD ------------------------------------------------------------------
pars.method = opts.method;
switch lower(opts.method)
    case {'dr'}
        pars.methodFunc = @direct_method_v5b;
        pars.methodNum = 1;
    case {'gs'}
        pars.methodFunc = @gaussian_method_v7_1_0;
        pars.methodNum = 2;
    otherwise
        msg = ['Undefined method ' pars.method];
        error('buildParsStruct:methodNotFound', msg);
end;

% BIAS --------------------------------------------------------------------
switch lower(opts.bias)
    case 'naive'
        pars.biasCorrNum = 0;
    case 'qe'
        pars.biasCorrNum = 1;
    case 'pt'
        pars.biasCorrNum = 2;
    case 'gsb'
        pars.biasCorrNum = 3;
    otherwise
        msg = ['Bias correction option ''' opts.bias ''' not found'];
        error('buildParsStruct:biasCorrNotFound', msg);
end


% BTSP (optional) ---------------------------------------------------------
pars.numberOfSpecifiedOptions = 0;
if isfield(opts, 'btsp')
    pars.numberOfSpecifiedOptions = pars.numberOfSpecifiedOptions + 1;
    
    if round(opts.btsp)~=opts.btsp
        msg = 'opts.btsp must be an integer.';
        error('buildParsStruct:btspNotInteger', msg);
    else
        pars.btsp = opts.btsp;
    end
else
    % No bootstrap:
    pars.btsp = 0;
end


% OUTPUT LIST -------------------------------------------------------------
% Checking which output-options have been selected and keeping track of the
% position they have in VARARGIN: this will allow do provide the outputs in
% the correct order.
pars.Noutput = length(varargin); % number of ouputs

varargin = lower(varargin);
pars.HR    = strcmpi(varargin, 'hr'      );
pars.HRS   = strcmpi(varargin, 'hrs'     );
pars.HlR   = strcmpi(varargin, 'hlr'     );
pars.HlRS  = strcmpi(varargin, 'hirs'    );
pars.HiR   = strcmpi(varargin, 'hir'     );
pars.ChiR  = strcmpi(varargin, 'chir'    );
pars.HshR  = strcmpi(varargin, 'hshr'    );
pars.HshRS = strcmpi(varargin, 'hshrs'   );
% See note in ENTROPY regarding this quantity:
pars.HiRS  = strcmpi(varargin, 'hirsdef' );

if pars.Nc>1
    pars.doHR    = any(pars.HR   );
    pars.doHRS   = any(pars.HRS  );
    pars.doHlR   = any(pars.HlR  );
    pars.doHlRS  = any(pars.HlRS );
    pars.doHiR   = any(pars.HiR  );
    pars.doHiRS  = any(pars.HiRS );
    pars.doChiR  = any(pars.ChiR );
    pars.doHshR  = any(pars.HshR );
    pars.doHshRS = any(pars.HshRS);
else
    pars.doHR    = any(pars.HR | pars.HlR | pars.HiR | pars.ChiR | pars.HshR);
    pars.doHRS   = any(pars.HRS | pars.HlRS | pars.HiRS | pars.HshRS);
    pars.doHlR   = false;
    pars.doHlRS  = false;
    pars.doHiR   = false;
    pars.doHiRS  = false;
    pars.doChiR  = false;
    pars.doHshR  = false;
    pars.doHshRS = false;
end

% ADDCHECKS (optionals) ---------------------------------------------------
if isfield(opts, 'verbose') && opts.verbose
    pars.numberOfSpecifiedOptions = pars.numberOfSpecifiedOptions + 1;
    pars.lengthVarargin = length(varargin);
    
    pars.addChecks = true;
else
    pars.addChecks = false;
end

if any(pars.addChecks)
	additional_checks_v4(R, pars, opts);
end;
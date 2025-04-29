import { ethers as hre } from 'hardhat'; // hardhat을 사용할 때 hre 라는 이름으로 사용합니다.
import { makeAbi } from './makeABI';
import { ethers } from 'ethers';
import { admin } from '../helper/test.helper';

import Proxy from '../abis/Proxy.json';

async function main() {
  // 1. Proxy 컨트랙트 인스턴스 생성 (ethers.js 기준, signer = admin)
  const proxy = new ethers.Contract(Proxy.address, Proxy.abi, admin);
  // 2. V2 컨트랙트 준비 (hardhat에서 가져오기
  const V2 = await hre.getContractFactory('V2');

  console.log('Deploying Contract...');

  /*
    Todo: 배포 스크립트(hardhat 사용)와 업그레이드(ethers 사용)를 완성시켜 주세요.

    1) V2 컨트랙트를 배포하기 위한 스크립트를 완성 시킵니다.
    2) 업그레이드를 실행합니다. Proxy 컨트랙트에서 upgrade 함수를 실행시켜야 합니다. 
  */
  // 3. V2 배포 
  const v2 = await V2.deploy();
  await v2.waitForDeployment();

  const V2Address = await v2.getAddress();
  console.log('V2 deployed to:', V2Address);

  // 4. Proxy 업그레이드 (V2 주소로)
  console.log('Upgrading proxy to V2...');
  const tx = await proxy.upgrade(V2Address);
  await tx.wait();

  // 5. ABI 저장 (V2 ABI, Proxy 주소)
  /* setting */
  console.log('Contract deployed to:', v2.target);
  await makeAbi('V2', `${proxy.target}`);  // address를 proxy 주소로 줌 
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

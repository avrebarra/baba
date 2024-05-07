const useDictionary = async () => {
  const resp = await fetch(DICTIONARY_URL);
  const respdata = await resp.json();
  return respdata;
};

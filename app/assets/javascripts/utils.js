window.ST = window.ST || {};

ST.utils = (function(_) {

  function findNextIndex(arr, fn) {
    if(arr.length < 2) {
      return -1;
    } else {
      var idx = _.findIndex(arr, fn);
      return idx !== -1 && idx < arr.length - 1 ? idx + 1 : -1;
    }
  }

  function findPrevIndex(arr, fn) {
    if (arr.length < 2) {
      return -1;
    } else {
      var idx = _.findIndex(arr, fn);
      return idx !== -1 && idx > 0 ? idx - 1 : -1;
    }
  }

  function swapArrayElements(arr, idx1, idx2, deep) {
    deep = deep || false;

    var newArr = _.clone(arr, deep);
    newArr[idx1] = arr[idx2];
    newArr[idx2] = arr[idx1];
    return newArr;
  }

  return {
    findNextIndex: findNextIndex,
    findPrevIndex: findPrevIndex,
    swapArrayElements: swapArrayElements
  };

})(_);